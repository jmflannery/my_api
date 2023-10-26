require "test_helper"

describe Post do
  let(:user) { create(:user) }
  subject    { build(:post, user: user) }

  before do
    @unpublished_post      = create(:post, user: user)
    @future_published_post = create(:published_in_future_post, user: user)
    @published_post        = create(:published_post, user: user)
    @other_published_post  = create(:published_post, user: user)
  end

  it 'should be valid' do
    expect(subject).must_be :valid?
  end

  describe 'scope published' do
    it 'should only return Posts with past or present published_at dates' do
      posts = Post.published
      post_ids = posts.map { |p| p['id'] }
      expect(post_ids.size).must_equal 2
      expect(post_ids).must_be :include?, @published_post.id
      expect(post_ids).must_be :include?, @other_published_post.id
      expect(post_ids).wont_be :include?, @unpublished_post.id
      expect(post_ids).wont_be :include?, @future_published_post.id
      expect(post_ids).wont_be :include?, subject.id
    end
  end

  describe 'last_edited_on' do
    describe 'when the Post is unpublished' do
      it 'should NOT update last_edited_on' do
        expect(subject.published_at).must_be_nil
        expect(subject.last_edited_at).must_be_nil
        subject.update(title: 'The new title', body: 'The new body')
        expect(subject.last_edited_at).must_be_nil
      end
    end

    describe 'when the Post is published' do
      before do
        subject.publish!
      end

      describe 'when body is updated' do
        it 'should update last_edited_on' do
          expect(subject.published_at).wont_be_nil
          expect(subject.last_edited_at).must_be_nil
          subject.update(title: 'The new title', body: 'The new body')
          expect(subject.last_edited_at).wont_be_nil
        end
      end

      describe 'when body is NOT updated' do
        it 'should NOT update last_edited_on' do
          expect(subject.published_at).wont_be_nil
          expect(subject.last_edited_at).must_be_nil
          subject.update(title: 'The new title')
          expect(subject.last_edited_at).must_be_nil
        end
      end
    end
  end

  describe '#publish!' do
    it 'should set published_at on the Post to the current time' do
      before_time = Time.current
      expect(subject.published_at).must_be_nil
      subject.publish!
      expect(subject.published_at).must_be :>, before_time
    end
  end

  describe '#unpublish!' do
    before do
      subject.publish!
    end

    it 'should set published_at on the Post to nil' do
      subject.unpublish!
      expect(subject.published_at).must_be_nil
    end
  end
end
