module SettingsHelper
  def text_connect_provider(provider)
    I18n.t('views.settings.account.connect_with', provider: provider_name(provider))
  end

  def text_disconnect_provider(provider)
    I18n.t('views.settings.account.disconnect_provider', provider: provider_name(provider))
  end
end
