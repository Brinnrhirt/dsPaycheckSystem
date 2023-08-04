Locales = {}
local language = Config.Locale
function _U(str, ...)
    if language == nil then
        --dbg.critical('Cannot found in config Locale')
        return 'not_found_config'
    end

    if Locales[language] == nil then
        --dbg.critical('Cannot found locale %s', language)
        return 'not_found_locale'
    end

    --- Nested translation string handling
    -- For translations in nested categories like Locales[en].business.bossmenu_text
    local isNested = not not string.find(str, ".", 1, true)

    if isNested then
        local cat, str = str:match('([^.]+).([^.]+)')

        if Locales[language][cat] == nil then
           -- dbg.critical('Cannot found locale category %s for string %s in locale %s', cat, str, language)
            return str
        end

        if Locales[language][cat][str] == nil then
            --dbg.critical('Cannot found locale string %s in category %s in locale %s', str, cat, language)
            return str
        end

        return string.format(Locales[language][cat][str], ...)
    end


    if Locales[language][str] == nil then
        --dbg.critical('Cannot found locale string %s in locale %s', str, language)
        return str
    end

    return string.format(Locales[language][str], ...)
end
