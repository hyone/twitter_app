require 'rails_helper'


describe 'Follow/Unfollow button', type: :feature do
  let (:user) { FactoryGirl.create(:user) }
  let (:other_user) { FactoryGirl.create(:user) }

  subject { page }

  before { visit user_path(other_user) }

  context 'as guest' do
    context 'when click follow button' do
      before { click_on I18n.t('views.navigation.follow') }

      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  context 'as user' do
    before {
      signin user
      visit current_path
    }

    context 'about follow button' do
      it { should have_selector ('.follow-button') }

      it 'should be 0 followers' do
       expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
      end

      context 'when click the button' do
        it 'should follow other_user' do
          expect {
            click_on I18n.t('views.navigation.follow')
          }.to change {
            Relationship.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.from(nil)
        end

        it "'follow' button should change to 'unfollow' button", js: true do
          click_on I18n.t('views.navigation.follow')
          expect(page).to have_selector('.unfollow-button')
        end

        it 'should be 1 followers', js: true do
          click_on I18n.t('views.navigation.follow')
          expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
        end
      end
    end

    context 'about unfollow button' do
      before {
        FactoryGirl.create(:relationship, follower: user, followed: other_user)
        visit current_path
      }

      it { should have_selector ('.unfollow-button') }

      it 'should be 1 followers' do
       expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
      end

      context 'when click the button' do
        it 'should unfollow other_user' do
          expect {
            click_on I18n.t('views.navigation.unfollow')
          }.to change {
            Relationship.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.to(nil)
        end

        it "'unfollow' button changes to 'follow' button", js: true do
          click_on I18n.t('views.navigation.follow')
          expect(page).to have_selector('.follow-button')
        end

        it 'should be 0 followers', js: true do
          click_on I18n.t('views.navigation.follow')
          expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
        end
      end
    end
  end
end