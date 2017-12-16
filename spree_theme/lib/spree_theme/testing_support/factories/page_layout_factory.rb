FactoryGirl.define do
  factory :page_layout, class: Spree::PageLayout do
    title 'page layout'
  end

  #   root
  #     node1
  #     node2 - pv(1)
  #       node21 - pv(2)
  #       node22 - pv(2)
  factory :page_layout_tree, class: Spree::PageLayout do
    title 'page layout tree'
    association :section, factory: :section_root
    after(:create) do |pl, evaluator|
      create( :page_layout_node, parent: pl)
      create( :page_layout_node_with_children, parent: pl)
    end
  end


  #   root
  #     node1(stylish1) -
  #     node2(stylish2) - pv(1)
  #       node21 - pv(2)
  #       node22 - pv(2)
  factory :page_layout_stylish_01, class: Spree::PageLayout do
    title 'page layout stylish tree'
    stylish 0
    after(:create) do |pl, evaluator|
      create( :page_layout_node, parent: pl, template_theme: pl.template_theme, stylish: 1)
    end
  end
  factory :page_layout_stylish_10, class: Spree::PageLayout do
    title 'page layout stylish tree'
    stylish 1
    after(:create) do |pl, evaluator|
      create( :page_layout_node, parent: pl, template_theme: pl.template_theme, stylish: 0)
    end
  end


  factory :page_layout_node, class: Spree::PageLayout do
    association :section, factory: :section
    title 'page layout node'
    after(:create) do |pl, evaluator|
      create_list( :param_value_simple, 2, page_layout: pl)
    end
  end

  factory :page_layout_node_with_children, class: Spree::PageLayout do
    association :section, factory: :section
    title 'page layout node with children'
    after(:create) do |pl, evaluator|
      create_list(:param_value_simple, 1, page_layout: pl)
      create_list(:page_layout_node, 2, parent: pl)
    end
  end

  factory :page_layout_root, class: Spree::PageLayout do
    association :section, factory: :section_root
    title 'page layout root'
  end

  factory :param_value_simple, class: Spree::ParamValue do
    pvalue { {'21'=> 'width:200px', '21unset'=> false} }
  end

end
