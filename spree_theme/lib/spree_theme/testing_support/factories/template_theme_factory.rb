FactoryGirl.define do
  factory :template_theme, class: Spree::TemplateTheme do
    title 'template theme'
    after(:create) do |theme, evaluator|
      create( :page_layout, template_theme: theme)
    end

    # template_theme
    #    page_layout
    #    template_release
    factory :published_template_theme, class: Spree::TemplateTheme do
      is_public true
      after(:create) do |theme, evaluator|
        create_list(:template_release, 1, template_theme: theme)
      end
    end

  end

  factory :template_release, class: Spree::TemplateRelease do
    name 'tempalte release'
  end

  factory :stylished_template_theme, class: Spree::TemplateTheme do
    title 'template theme'
    transient do
      stylish 1
    end
    after(:create) do |theme, evaluator|
      create( :page_layout, template_theme: theme, stylish: evaluator.stylish )
    end
  end

  factory :template_theme_stylish_tree, class: Spree::TemplateTheme do
    title 'template theme'
    transient do
      stylish '01'
    end
    after(:create) do |theme, evaluator|
      create( "page_layout_stylish_#{evaluator.stylish}", template_theme: theme)
    end
  end

  # template_theme
  #      page_layout_root
  #          section_root
  #             section_piece_root
  factory :previewable_template_theme, class: Spree::TemplateTheme do
    title 'template theme for preview'
    store
    after(:create) do |theme, evaluator|
      create(:page_layout_root, template_theme: theme)

    end
  end


  # template_theme
  #      page_layout_root
  #              page_layout_nodes( size=2)
  #                       param_values( size=5, theme_id, page_layout_id )

  factory :duplicatabl_template_theme, class: Spree::TemplateTheme do
    title 'full template theme'
    after(:create) do |theme, evaluator|
      create(:page_layout_tree_for_duplicator, template_theme: theme)
    end
  end

  factory :page_layout_for_duplicator, class: Spree::PageLayout do
    title 'page layout node'
    after(:create) do |pl, evaluator|
      create_list( :param_value_for_duplicator, 5, template_theme: pl.template_theme, page_layout: pl)
    end

    factory :page_layout_tree_for_duplicator, class: Spree::PageLayout do
      title 'page layout tree'
      after(:create) do |pl, evaluator|
        create( :page_layout_for_duplicator, parent: pl, template_theme: pl.template_theme)
        create( :page_layout_for_duplicator, parent: pl, template_theme: pl.template_theme)
      end
    end

  end

  factory :param_value_for_duplicator, class: Spree::ParamValue do
    pvalue { {'21'=> 'width:200px', '21unset'=> false} }
  end

end
