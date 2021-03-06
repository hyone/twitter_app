module ApplicationHelper
  def page_title(text = nil)
    base = I18n.t('base_title')
    return base if text.blank?
    [text, base].join(' | ')
  end

  def username_formatted(user)
    "#{user.name} (@#{user.screen_name})"
  end

  def provider_name(provider)
    s = provider.to_s
    case s
    when 'google_oauth2' then 'google'
    else s
    end
  end

  # From https://github.com/tnantoka/miclo/
  def decode_bindings(encoded)
    space = '(\+|%20)'
    encoded
      .gsub(/%7B%7B#{space}*/i, '{{').gsub(/#{space}*%7D%7D/i, '}}') # delimiters
      .gsub(/#{space}%7C#{space}/i, ' | ') # filter
      .gsub(/\+%2B\+/i, ' + ') # expression
  end

  def bindable_path(path, *args)
    decode_bindings(send("#{path}_path", *args))
  end
end
