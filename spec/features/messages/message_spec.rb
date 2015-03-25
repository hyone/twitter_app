require 'rails_helper'
include ActionView::Helpers::DateHelper


describe 'Message Block', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user, created_at: 2.hours.ago) }

  subject { page }

  before { visit user_path(user) }

  it { should have_link(message.user.name, user_path(message.user)) }
  it { should have_link("@#{message.user.screen_name}", user_path(message.user)) }
  it { should have_link("2 hours ago", user_path(message.user)) }

  describe 'context block' do
    context 'when retweeted message' do
      let! (:retweet) { FactoryGirl.create(:retweet, user: user) }
      before { visit current_path }

      it 'should display retweet context message' do
        expect(page).to have_selector('.message-context', I18n.t('views.message_panel.retweeted'))
        expect(page).to have_selector('.message-context', retweet.user.screen_name)
      end
    end
  end

  describe 'message text block' do
    include_examples 'a message textable block' do
      def path(message)
        with_replies_user_path(message.user)
      end
    end

    context 'when keyword is highlighted' do
      let! (:message1) { FactoryGirl.create(:message, text: 'hello World 1') }
      let! (:compliment) { FactoryGirl.create(:user, screen_name: 'world') }
      let! (:message2) { FactoryGirl.create(:message_with_reply, users_replied_to: [compliment] ) }
      let (:keyword) { 'worl' }
      before { visit search_path('q[text]' => keyword) }

      it 'should highlight (replace) text' do
        expect(page).to have_selector(
          "#message-#{message1.id} .message-body strong",
          text: keyword.camelcase
        )
      end

      it 'should highlight only text node and not url in link' do
        expect(page).to have_selector(
          "#message-#{message2.id} .message-body a[href='#{user_path(compliment)}'] strong",
          text: keyword
        )
      end
    end
  end

  describe 'message actions block' do
    def path(message)
      user_path(message.user)
    end

    describe 'reply button' do
      include_examples 'a replyable button'
    end
    describe 'retweet button' do
      include_examples 'a retweetable button'
    end
    describe 'favorite button' do
      include_examples 'a favoritable button', content_navigation: true
    end
    describe 'actions button' do
      include_examples 'a message actionable button'
    end
  end
end
