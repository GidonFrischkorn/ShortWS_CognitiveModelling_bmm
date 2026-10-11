function Math(el)
  if FORMAT:match("html") or FORMAT == "revealjs" then
    if el.mathtype == "DisplayMath" and el.text:match("\\begin{aligned}") then
      local html = pandoc.write(pandoc.Pandoc({pandoc.Plain({el})}), "html5",
        {html_math_method = "mathml"})
      local cells = {}
      for content in html:gmatch("<mtd[^>]*>(.-)</mtd>") do
        cells[#cells + 1] = "<mrow>" .. content .. "</mrow>"
      end
      local strut = '<mpadded width="0" aria-hidden="true"><mphantom><mrow>'
        .. table.concat(cells) .. '</mrow></mphantom></mpadded>'
      return pandoc.RawInline("html", html:gsub("(<mtd[^>]*>)", "%1" .. strut))
    end
  end
end
