require 'rails_helper'
include SettingsHelper

describe 'Settings Page' do
  def submit
    click_on I18n.t('settings.form.submit')
  end

  subject { page }

  let(:current_password) { 'password' }
  let(:user) do
    FactoryGirl.create(
      :user,
      password: current_password,
      password_confirmation: current_password
    )
  end

  describe 'GET /settings/account', js: true do
    context 'as guest' do
      def path
        settings_account_path
      end
      include_examples 'a user requirable page'
    end

    context 'as user' do
      before do
        signin user
        visit settings_account_path
      end

      its(:status_code) { should == 200 }

      describe 'content' do
        it { should have_title(I18n.t('settings.title')) }

        it { should have_content(I18n.t('settings.account.title')) }
        it { should have_content(I18n.t('settings.account.subtitle')) }
      end

      describe 'Form' do
        context 'when user has not set password yet' do
          let!(:user) do
            u = FactoryGirl.build(:user, password: nil, password_confirmation: nil)
            u.save(validation: nil)
            u
          end
          before do
            signin user
            visit settings_account_path
          end

          it 'should disable input forms' do
            should have_selector('input.form-control[disabled=disabled]')
            should_not have_selector('input.form-control[disabled=false]')
          end

          it 'should disable submit button' do
            should have_selector('button.btn-primary.disabled')
          end
        end

        context "when click 'Save Changes' button" do
          let!(:new_email) { 'changed@example.com' }
          before do
            fill_in 'user[email]', with: new_email
            click_on 'settings-confirm-password-button'
          end

          it 'should display password dialog' do
            expect(page.find('#password-dialog')).to be_visible
          end

          context 'and then click cancel button' do
            it 'should not modify settings' do
              expect do
                click_on 'settings-account-cancel-button'
              end.not_to change {
                user.reload.email
              }.from(user.email)
            end

            it 'should dismiss password dialog' do
              click_on 'settings-account-cancel-button'
              expect(page.find('#password-dialog', visible: false)).not_to be_visible
            end
          end

          context 'and then submit password' do
            it 'should modify settings' do
              expect do
                fill_in 'user[current_password]', with: 'password'
                click_on 'settings-account-submit-button'
              end.to change {
                user.reload.email
              }.from(user.email).to(new_email)
            end
          end
        end
      end

      # oauth
      describe 'OAuth' do
        let!(:provider) { 'developer' }
        let!(:text_connect) { text_connect_provider(provider) }
        let!(:text_disconnect) { text_disconnect_provider(provider) }
        before { setup_omniauth(provider) }

        # require:
        # - let(:authentication) { ... }
        shared_examples 'an disconnectable provider link' do
          it { should_not have_link(text_connect, user_omniauth_authorize_path(provider)) }
          it { should have_link(text_disconnect_provider(provider), authentication_path(authentication)) }
        end

        shared_examples 'an connectable provider link' do
          it { should have_link(text_connect, user_omniauth_authorize_path(provider)) }
          it { should_not have_link(text_disconnect_provider(provider), authentication_path(authentication)) }
        end

        context 'when have not linked to provider' do
          it { should have_link(text_connect, user_omniauth_authorize_path(provider)) }

          context 'after clicking the link to connect provider' do
            before do
              click_link text_connect_provider(provider)
              # back to setting page
              visit settings_account_path
            end

            include_examples 'an disconnectable provider link' do
              let(:authentication) { user.authentications.find_by(provider: provider) }
            end
          end
        end

        context 'when have already linked to provider' do
          let!(:authentication) do
            FactoryGirl.create(:authentication, provider: provider, user: user)
          end
          before { visit settings_account_path }

          include_examples 'an disconnectable provider link'

          context 'and then the user has not set password yet' do
            let!(:user) do
              u = FactoryGirl.build(:user, password: nil, password_confirmation: nil)
              u.save(validation: nil)
              u
            end
            before do
              # replace the user with one without password
              authentication.user = user
              signin user
              visit settings_account_path
            end

            it 'should have disabled link "Disconnect provider"' do
              should have_selector('a.disabled', text: text_disconnect_provider(provider))
            end
          end

          context 'after clicking the link to disconnect provider' do
            before do
              click_link text_disconnect
              visit settings_account_path
            end
            include_examples 'an disconnectable provider link'
          end
        end
      end

      describe 'Danger Zone' do
        it { should have_link(I18n.t('settings.account.deactivate'), delete_user_registration_path(user)) }

        context 'when click user delete button' do
          before { click_on I18n.t('settings.account.deactivate') }

          it 'should display confirm dialog' do
            expect(page.find('#confirm-dialog')).to be_visible
          end

          context 'when click cancel button' do
            it 'should not delete user account' do
              expect do
                click_on 'cancel-action-button'
                wait_for_ajax
              end.not_to change {
                User.exists?(user.id)
              }.from(true)
            end

            it 'should dismiss confirm dialog' do
              click_on 'cancel-action-button'
              expect(page.find('#confirm-dialog', visible: false)).not_to be_visible
            end
          end

          context 'when click ok button' do
            def click_ok_button
              click_on 'ok-action-button'
              wait_for_ajax
            end

            it 'should delete user account' do
              expect { click_ok_button }.to change {
                User.exists?(user.id)
              }.to(false)
            end
          end
        end
      end
    end
  end

  describe 'GET /settings/password', js: true do
    context 'as guest' do
      def path
        settings_password_path
      end
      include_examples 'a user requirable page'
    end

    context 'as user' do
      before do
        signin user
        visit settings_password_path
      end

      let(:new_password) { 'new_password' }

      shared_examples 'a password is not changed' do
        it 'should not change password' do
          expect do
            submit
          end.not_to change {
            user.reload.encrypted_password
          }.from(user.encrypted_password)
        end
      end

      def error_message(model, attribute, messaage, subject = attribute)
        model.errors.full_message(
          attribute, model.errors.generate_message(subject, messaage)
        )
      end

      its(:status_code) { should == 200 }

      context 'without current password' do
        before do
          fill_in 'user[password]', with: new_password
          fill_in 'user[password_confirmation]', with: new_password
        end

        include_examples 'a password is not changed'

        it do
          submit
          expect(page).to have_alert(:error, error_message(user, :current_password, :blank))
        end
      end

      context 'with invalid current password' do
        before do
          fill_in 'user[password]', with: new_password
          fill_in 'user[password_confirmation]', with: new_password
          fill_in 'user[current_password]', with: current_password + 'wrong'
        end

        include_examples 'a password is not changed'

        it do
          submit
          expect(page).to have_alert(:error, error_message(user, :current_password, :invalid))
        end
      end

      context 'without password and password confirmation' do
        before do
          fill_in 'user[current_password]', with: current_password
        end

        include_examples 'a password is not changed'

        it do
          submit
          expect(page).to have_alert(:error, error_message(user, :password, :blank))
          expect(page).to have_alert(:error, error_message(user, :password_confirmation, :blank))
        end
      end

      context 'with password and password confirmation do not match' do
        before do
          fill_in 'user[password]', with: new_password
          fill_in 'user[password_confirmation]', with: new_password  + 'wrong'
          fill_in 'user[current_password]', with: current_password
        end

        include_examples 'a password is not changed'

        it do
          submit
          expect(page).to have_alert(:error, error_message(user, :password_confirmation, :confirmation, :password))
        end
      end

      context 'with valid parameters' do
        before do
          fill_in 'user[password]', with: new_password
          fill_in 'user[password_confirmation]', with: new_password
          fill_in 'user[current_password]', with: current_password
        end

        it 'should change password' do
          expect do
            submit
          end.to change {
            user.reload.encrypted_password
          }.from(user.encrypted_password)
        end

        it do
          submit
          should_not have_alert(:alert)
        end
      end
    end
  end

  describe 'GET /settings/profile', js: true do
    context 'as guest' do
      def path
        settings_password_path
      end
      include_examples 'a user requirable page'
    end

    context 'as user' do
      before do
        signin user
        visit settings_profile_path
      end

      context 'with valid parameters' do
        let(:new_url) { 'http://wwww.example.com/' }
        before do
          fill_in 'user[url]', with: new_url
        end

        it 'should change password' do
          expect do
            submit
          end.to change {
            user.reload.url
          }.from(user.url).to(new_url)
        end
      end
    end
  end
end
