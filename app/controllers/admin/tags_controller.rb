module Admin
  class TagsController < BaseController
    before_action :set_tag, only: [ :edit, :update, :destroy ]

    def index
      tags = Tag.ordered
      if params[:q].present?
        q = "%#{params[:q]}%"
        tags = tags.where("name->>'en' ILIKE :q OR name->>'bn' ILIKE :q", q: q)
      end
      @pagy, @tags = pagy(tags)
    end

    def new
      @tag = Tag.new
    end

    def create
      @tag = Tag.new(tag_params)
      if @tag.save
        redirect_to admin_tags_path, notice: "Tag created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @tag.update(tag_params)
        redirect_to admin_tags_path, notice: "Tag updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @tag.destroy
      redirect_to admin_tags_path, notice: "Tag deleted."
    end

    private

    def set_tag
      @tag = Tag.friendly.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name_en, :name_bn)
    end
  end
end
