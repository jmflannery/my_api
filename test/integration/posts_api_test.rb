require 'test_helper'

describe 'Posts API' do
  let(:current_user) { create(:user) }

  describe 'POST create' do
    before do
      title = "How to write #{Faker::ProgrammingLanguage.name} like a pro"
      @params = {
        title:        title,
        slug:         title.split(' ').join('-'),
        description:  Faker::Hacker.say_something_smart,
        body:         Faker::Lorem.paragraphs(number: 3).join("\n")
      }
    end

    describe 'if the request includes valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should create a Post' do
        post '/posts', post: @params
        post = JSON.parse(last_response.body)
        expect(last_response.status).must_equal 201
        expect(post['id']).must_be :>=, 1
        expect(post['title']).must_equal @params[:title]
        expect(post['description']).must_equal @params[:description]
        expect(post['body']).must_equal @params[:body]
        expect(post['slug']).must_equal @params[:slug]
      end
    end

    describe 'if the request includes a valid Authorization header' do
      before do
        sign_in_with_header current_user
      end

      it 'should create a Post' do
        post '/posts', post: @params
        post = JSON.parse(last_response.body)
        expect(last_response.status).must_equal 201
        expect(post['id']).must_be :>=, 1
        expect(post['title']).must_equal @params[:title]
        expect(post['description']).must_equal @params[:description]
        expect(post['body']).must_equal @params[:body]
        expect(post['slug']).must_equal @params[:slug]
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      it 'should return 401 Unauthorized' do
        post '/posts', post: @params

        expect(last_response.status).must_equal 401
      end
    end
  end

  describe 'GET index' do
    let(:other_user) { create(:user) }
    before do
      @unpublished_post = create(:post, user: current_user)
      @published_post_1 = create(:published_post, user: current_user)
      @published_post_2 = create(:published_post, user: current_user)
      @op_post          = create(:post, user: other_user)
    end

    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should return all Posts belonging to the current_user descending by created_at' do
        get '/posts'
        expect(last_response.status).must_equal 200
        posts = JSON.parse(last_response.body)
        expect(posts.size).must_equal 3
        expect(posts[0]['id']).must_equal @published_post_2.id
        expect(posts[1]['id']).must_equal @published_post_1.id
        expect(posts[2]['id']).must_equal @unpublished_post.id
        expect(posts[0]['slug']).must_equal @published_post_2.slug
        expect(posts[1]['slug']).must_equal @published_post_1.slug
        expect(posts[2]['slug']).must_equal @unpublished_post.slug
        expect(posts[0]['title']).must_equal @published_post_2.title
        expect(posts[1]['title']).must_equal @published_post_1.title
        expect(posts[2]['title']).must_equal @unpublished_post.title
      end
    end

    describe 'if the request includes a valid Authorization header' do
      before do
        sign_in_with_header current_user
      end

      it 'should return all Posts belonging to the current_user descending by created_at' do
        get '/posts'
        expect(last_response.status).must_equal 200
        posts = JSON.parse(last_response.body)
        expect(posts.size).must_equal 3
        expect(posts[0]['id']).must_equal @published_post_2.id
        expect(posts[1]['id']).must_equal @published_post_1.id
        expect(posts[2]['id']).must_equal @unpublished_post.id
        expect(posts[0]['slug']).must_equal @published_post_2.slug
        expect(posts[1]['slug']).must_equal @published_post_1.slug
        expect(posts[2]['slug']).must_equal @unpublished_post.slug
        expect(posts[0]['title']).must_equal @published_post_2.title
        expect(posts[1]['title']).must_equal @published_post_1.title
        expect(posts[2]['title']).must_equal @unpublished_post.title
      end
    end

    describe 'if the request does not include a valid auth_key cookie or header' do
      it 'should return only published Posts descending by published_at' do
        get '/posts'
        expect(last_response.status).must_equal 200
        posts = JSON.parse(last_response.body)
        expect(posts.size).must_equal 2 
        expect(posts[0]['id']).must_equal @published_post_2.id
        expect(posts[1]['id']).must_equal @published_post_1.id
        expect(posts[0]['slug']).must_equal @published_post_2.slug
        expect(posts[1]['slug']).must_equal @published_post_1.slug
        expect(posts[0]['title']).must_equal @published_post_2.title
        expect(posts[1]['title']).must_equal @published_post_1.title
      end
    end
  end

  describe 'GET show' do
    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      describe 'if requesting an unpublished Post' do
        subject { create(:post, user: current_user) }

        it 'should return the Post' do
          get "/posts/#{subject.id}"
          post = JSON.parse(last_response.body)
          expect(last_response.status).must_equal 200
          expect(post['id']).must_equal subject.id
        end
      end

      describe 'if requesting a invalid Post id' do
        it 'should return 404 Not Found' do
          get "/posts/wrong"
          expect(last_response.status).must_equal 404
        end
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      describe 'if requesting a published Post' do
        subject { create(:published_post, user: current_user) }

        it 'should return the Post' do
          get "/posts/#{subject.id}"
          post = JSON.parse(last_response.body)
          expect(last_response.status).must_equal 200
          expect(post['id']).must_equal subject.id
        end
      end

      describe 'if requesting an unpublished Post' do
        subject { create(:post, user: current_user) }

        it 'should return 404 Not Found' do
          get "/posts/#{subject.id}"
          expect(last_response.status).must_equal 404
        end
      end
    end
  end

  describe 'PUT update' do
    subject { create(
      :post,
      title:        'My title',
      slug:         'my-title',
      description:  'My Description',
      body:         'My body',
      user:         current_user
    )}
    let(:params) {{
      title:        'My Updated Title',
      slug:         'my-updated-title',
      description:  'My Updated Description',
      body:         'My updated body',
    }}

    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should update the Post' do
        put "/posts/#{subject.id}", post: params
        post = JSON.parse(last_response.body)

        expect(last_response.status).must_equal 200
        expect(post['id']).must_equal subject.id
        expect(post['title']).must_equal params[:title]
        expect(post['description']).must_equal params[:description]
        expect(post['body']).must_equal params[:body]
        expect(post['slug']).must_equal params[:slug]
      end

      describe 'given in invalid Post id' do
        it 'should return 404 Not Found' do
          put "/posts/wrong", post: params
          expect(last_response.status).must_equal 404
        end
      end

      describe 'if the Post is published' do
        before do
          subject.publish!
        end

        it 'should update `last_edited_at` when `body` is updated' do
          before_time = Time.current
          put "/posts/#{subject.id}", post: params
          post = JSON.parse(last_response.body)
          expect(post['last_edited_at']).must_be :>, before_time
        end
      end
    end

    describe 'if the request includes a valid Authorization header' do
      before do
        sign_in_with_header current_user
      end

      it 'should update the Post' do
        put "/posts/#{subject.id}", post: params
        post = JSON.parse(last_response.body)

        expect(last_response.status).must_equal 200
        expect(post['id']).must_equal subject.id
        expect(post['title']).must_equal params[:title]
        expect(post['description']).must_equal params[:description]
        expect(post['body']).must_equal params[:body]
        expect(post['slug']).must_equal params[:slug]
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      it 'should return 401 Unauthorized' do
        put "/posts/#{subject.id}", post: params
        expect(last_response.status).must_equal 401
      end
    end
  end

  describe 'DELETE destroy' do
    subject { create(:published_post, user: current_user) }

    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should delete the Post and return 204 No Content' do
        delete "/posts/#{subject.id}"
        expect(last_response.status).must_equal 204
        assert_raises(ActiveRecord::RecordNotFound) do
          subject.reload
        end
      end

      describe 'given in invalid Post id' do
        it 'should return 404 Not Found' do
          delete '/posts/wrong'
          expect(last_response.status).must_equal 404
        end
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      it 'should return 401 Unauthorized' do
        delete "/posts/#{subject.id}"
        expect(last_response.status).must_equal 401
      end
    end
  end

  describe 'PUT publish' do
    subject { create(:post, user: current_user) }

    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should publish the Post and return 200 Ok and the Post' do
        before_time = Time.current
        expect(subject.published_at).must_be_nil
        put "/posts/#{subject.id}/publish"
        published_post = JSON.parse(last_response.body)
        expect(last_response.status).must_equal 200
        expect(published_post['id']).must_equal subject.id
        expect(published_post['published_at']).must_be :>, before_time
      end

      describe 'given in invalid Post id' do
        it 'should return 404 Not Found' do
          put '/posts/wrong/publish'
          expect(last_response.status).must_equal 404
        end
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      it 'should return 401 Unauthorized' do
        put "/posts/#{subject.id}/publish"
        expect(last_response.status).must_equal 401
      end
    end
  end

  describe 'PUT unpublish' do
    subject { create(:published_post, user: current_user) }

    describe 'if the request includes a valid auth_key cookie' do
      before do
        sign_in current_user
      end

      it 'should publish the Post and return 200 Ok and the Post' do
        expect(subject.published_at).wont_be_nil
        put "/posts/#{subject.id}/unpublish"
        unpublished_post = JSON.parse(last_response.body)
        expect(last_response.status).must_equal 200
        expect(unpublished_post['id']).must_equal subject.id
        expect(unpublished_post['published_at']).must_be_nil
      end

      describe 'given in invalid Post id' do
        it 'should return 404 Not Found' do
          put '/posts/wrong/unpublish'
          expect(last_response.status).must_equal 404
        end
      end
    end

    describe 'if the request does not include a valid auth_key cookie' do
      it 'should return 401 Unauthorized' do
        put "/posts/#{subject.id}/unpublish"
        expect(last_response.status).must_equal 401
      end
    end
  end
end
