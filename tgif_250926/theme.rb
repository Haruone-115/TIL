# -*- coding: utf-8 -*-

include_theme("default")

@slide_center = Proc.new do
  match(TitleSlide) do
    prop_set("vertical-align", "middle")
    prop_set("align", "center")
    prop_set("font-size", "x-large")
  end

  match(Slide, HeadLine) do |heads|
    heads.prop_set("vertical-align", "middle")
    heads.prop_set("align", "center")
    heads.prop_set("font-size", "large")
  end

  match(Slide, HorizontalRule) do |rules|
    rules.delete
  end
end

@slide_center.call
