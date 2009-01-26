$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module BoochTek
  module Rails
    module CrudActions
      VERSION = '0.0.3'
      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def crud_model=(model)
          @@current_model = (model.class == Class) ? model : model.constantize
        end
      end
        # This implementation based on http://blog.boldr.fr/posts/datamapper-0-9-avec-rails
        #before_filter :new_item,  :only => [:new, :create]
        #before_filter :find_item, :only => [:show, :edit, :update, :delete, :destroy]
        #before_filter :find_items, :only => [:index]
        #before_filter :fill_item, :only => [:create, :update]
        # TODO: after_filters for finding default views.
        # TODO: Filtering of items visible to a user.
        # TODO: Complex filtering of index, for searching. (Similar to Justin's solution.)
        # TODO: User-specifed model or collection.
        # TODO: Pagination.
        # TODO: Automatic rendering of a default page. (Separate module/gem.)
      def index
      end

      def show
      end

      def new
      end

      def edit
      end

      def delete
      end

      def create
        save_or_render 'new'
      end

      def update
        save_or_render 'edit'
      end

      def destroy
        @current_item.destroy
        respond_to do |format|
          format.html { redirect_to(self.send("#{current_model.table_name.singularize}_index_url")) }
          format.xml  { head :ok }
        end
      end

      protected

      def new_item
        @current_item = current_model.new
      end

      def find_item
        @current_item = current_model[params[:id]]
      end

      def find_items
        @current_items = current_model.all
      end

      def fill_item
        @current_item.attributes = params[:item]
      end

      def save_or_render(action)
        if @current_item.save
          redirect_to @current_item
        else
          render :action => action
        end
      end

      def current_model
        @@current_model ||= controller_name.singularize.camelize.constantize
      end

    end
  end
end
