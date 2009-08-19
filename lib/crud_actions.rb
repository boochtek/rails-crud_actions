# This implementation partly based on http://blog.boldr.fr/posts/datamapper-0-9-avec-rails

# USAGE:
#   crud_actions
#   crud_actions :model => Test
#   crud_actions :model => User
#   crud_actions :model => User, :scope => {:conditions => {:name => 'Bill'}}
#   crud_actions User, :conditions => {:name => 'Bill'} # TODO: Should we support this syntax? Should we drop the :model => User syntax?

# ANOTHER USAGE POSSIBILITY (works now):
#   include BoochTek::Rails::CrudActions
#   crud_options :model => Test
#   crud_options :scope => {:conditions => {:name => 'Bill'}}

# ANOTHER USAGE POSSIBILITY:
#   include BoochTek::Rails::CrudActions
#   crud_model Test
#   crud_scope :conditions => {:name => 'Bill'}


# FEATURES:
#   ?sort_by=column_name,another_column+ASC
#   ?page=12&per_page=10
#



module ActionController
  class Base
    def self.crud_actions(model_class=nil, options={})
      include BoochTek::Rails::CrudActions
      crud_options model_class, options
    end
  end
end


module BoochTek
  module Rails
    module CrudActions
      VERSION = '0.0.6'

      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods) # Have to use send(:include) because include is a private method.
        base.instance_eval do
          before_filter :crud_collection, :only => [:index]
          before_filter :crud, :only => [:show, :new, :edit, :delete, :create, :update, :destroy]
          helper_method :crud, :crud_collection # Make sure these are visible to the view.

          # Make all 8 of the default methods of the controller call the CRUD versions by default, while making it easy to override them.
          %w{index show new edit delete create update destroy}.each do | meth |
            alias_method meth, "crud_#{meth}" # FIXME: Make sure the caller can override all the standard methods (index, show, etc.) or we'll have to use define_method.
          end
        end
      end

      module ClassMethods
        def crud_options(model_class=nil, options={}) # Add options and/or return the options hash.
          options = model_class if options == {} and model_class.is_a?(Hash)
          options[:model] = model_class unless model_class.nil?
          (@crud_options ||= {}).merge!(options)
        end
      end

      module InstanceMethods
        def crud_index
          crud_collection.find_items
        end

        def crud_show
          crud.find_item(params[:id])
        end

        def crud_new
          crud.new_item
        end

        def crud_edit
          crud.find_item(params[:id])
        end

        def crud_delete
          crud.find_item(params[:id])
        end

        def crud_create
          return if cancel_button
          crud.new_item
          crud.fill_item(params)
          save_or_render
        end

        def crud_update
          return if cancel_button
          crud.find_item(params[:id])
          crud.fill_item(params)
          save_or_render
        end

        def crud_destroy
          return if cancel_button
          crud.find_item(params[:id])
          crud.item.destroy # FIXME: Can this fail?
          respond_to do |format|
            format.html { redirect_to(self.send("#{controller_name}_url")) } # FIXME: Need a better way to redirect to the index.
            format.xml  { head :ok }
          end
        end

        protected

        def crud
          @crud ||= BoochTek::Rails::CrudItem.new(self, self.class.crud_options)
        end

        def crud_collection
          @crud ||= BoochTek::Rails::CrudItems.new(self, self.class.crud_options)
        end

        # Allow a CANCEL button (instead of a link) that will redirect to the index, instead of performing the action.
        # We have to do it this way, because HTML forms only allow submission to a single URL for each form, and if we had a 2nd form, it'd be difficult to place the buttons next to each other.
        # NOTE: Must be called with 'return if cancel_button' so that the redirect_to takes effect immediately.
        # NOTE: We'd make this a before_filter (and return false to terminate the filter chain) if we were implementing it directly in the controller.
        # TODO: What if we want the cancel button to redirect to the show action when we cancel the edit action?
        def cancel_button
          if params['commit'].downcase == 'cancel'
            redirect_to :action => 'index'
            return true
          end
        end

        def save_or_render
          if crud.item.save
            flash[:notice] = 'Item has been saved' # TODO: We might want to say 'updated' or 'created' here, depending on if we were called from update or create action.            
            # TODO: Allow caller to decide whether to redirect to the show action or the index action.
            redirect_to self.send("#{controller_name.singularize}_url", crud.item.id) # FIXME: Need a better way to redirect to the show view of the object. For edit, it'd be easier to just do redirect_to :action => 'show'. Can we do redirect_to :action => 'show', :id => crud.item.id for edit and new?
          else
            render :template => "#{controller_name}/edit" # NOTE: This assumes that we use the edit template for both edit and new actions.
          end
        end

      end
    end
  end
end

module BoochTek
  module Rails
    class CrudContainer
      VERSION = '0.0.6'
      attr_reader :controller, :action
      attr_reader :model, :scope, :collection

      def initialize(controller, options = {})
        @controller = controller # TODO: Do we really need to have the initializer dependent on controller?
        @action = controller.action_name
        @model = options[:model] || controller.controller_name.singularize.camelize.constantize
        @model = @model.constantize unless (model.class == Class || model.is_a?(Enumerable))
        @scope = options[:scope] || {}
        @collection = options[:collection] || @model.scoped(@scope)
      end
    end

    class CrudItem < CrudContainer
      attr_reader :item
      attr_accessor :url, :post_to # FIXME: What is post_to for -- URL for forms to post to -- why would we need that?

      def initialize(controller, options = {})
        super
        # Normalize create/update actions to new/edit.
        @action = 'new' if @action == 'create'
        @action = 'edit' if @action == 'update'
      end

      def new_item
        @item = self.model.new
      end

      def find_item(id)
        @item = self.collection.find(id) # FIXME: Might find something not in the collection.
      end

      def fill_item(params)
        type = controller.controller_name.singularize.to_sym
        self.item.attributes = params[type]
      end
    end

    class CrudItems < CrudContainer
      ITEMS_PER_PAGE = 5
      attr_reader :items, :sort_by, :page, :items_per_page

      def initialize(controller, options = {})
        super
        @sort_by = controller.params[:sort_by] || options[:sort_by] || 'id'
        @page = [0, (controller.params[:page].to_i - 1)].min # Note that crud.page is 0-based, but params[:page] is 1-based. FIXME: Ensure not past last page.
        @items_per_page = controller.params[:per_page] || options[:per_page] || ITEMS_PER_PAGE
      end

      def find_items
        # Handle scoping for sorting and pagination. Make the results READ-ONLY (since we should never need to change anything in index-like actions).
        @items = @collection.scoped(:order => sort_by, :offset => first_item_index, :limit => items_per_page, :readonly => true)
      end

      # TODO: We should probably just use crud.collection.size everywhere.
      def total_item_count
        collection.size
      end

      # Index (0-based) of the first item on the current page. Pages are also 0-based.
      def first_item_index
        items_per_page * page
      end

      # Index (0-based) of the last item on the current page. Pages are also 0-based.
      def last_item_index
        [(items_per_page * (page+1)) - 1, total_item_count - 1].min
      end

      # Page number (0-based) of the last page. We should probably rename (and re-implement) this as page_count or number_of_pages or total_pages.
      def last_page
        [0, (collection.size - 1) / items_per_page].max
      end
    end

  end
end
