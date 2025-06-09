-- Enhanced PDF preview configuration for Yazi

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

return {
  -- PDF preview using pdftotext for text extraction and pdftoppm for image rendering
  pdf = function(path, args)
    local max_pages = 3
    local output = {}
    
    -- First try to extract text content for better search capability
    if file_exists("/opt/homebrew/bin/pdftotext") then
      local text_preview = io.popen("/opt/homebrew/bin/pdftotext -l " .. max_pages .. " -layout -q \"" .. path .. "\" -", "r")
      if text_preview then
        local text = text_preview:read("*a")
        text_preview:close()
        
        if text and #text > 0 then
          table.insert(output, { text = "📄 PDF Text Content:" })
          table.insert(output, { text = text })
        end
      end
    end
    
    -- Then try to render image preview for visual representation
    if file_exists("/opt/homebrew/bin/pdftoppm") then
      -- Create a temporary file for the image
      local tmp_file = os.tmpname() .. ".png"
      
      -- Convert first page to PNG image
      os.execute("/opt/homebrew/bin/pdftoppm -png -singlefile -scale-to 800 \"" .. path .. "\" \"" .. tmp_file:gsub("%.png$", "") .. "\"")
      
      -- Add the image to output if it exists
      if file_exists(tmp_file) then
        table.insert(output, { image = { path = tmp_file, width = args.width, height = args.height } })
        
        -- Schedule cleanup of the temporary file
        os.execute("rm \"" .. tmp_file .. "\" &")
      end
    end
    
    -- If no preview could be generated, show a message
    if #output == 0 then
      table.insert(output, { text = "⚠️ PDF preview not available. Make sure poppler is installed." })
      table.insert(output, { text = "Run: brew install poppler" })
    end
    
    return output
  end
}
