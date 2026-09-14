require "test_helper"

# Verifies the three bugs that were broken in the 2016 app, so a later reader
# does not mistake the fixes for regressions.
class PortVerificationTest < ActionDispatch::IntegrationTest
  setup do
    @color = Color.first
    @color.votes.destroy_all
    @color.update_column(:votes_count, 0)
  end

  test "bug 1: logged-out visitor can vote" do
    post vote_up_color_path(@color)
    assert_response :redirect
    assert_equal 1, @color.reload.votes_count
  end

  test "bug 1b: same visitor cannot vote twice" do
    post vote_up_color_path(@color)
    post vote_up_color_path(@color)
    assert_equal 1, @color.reload.votes_count
    assert_equal "You already voted!", flash[:alert]
  end

  test "bug 2: the alert branch actually renders" do
    post vote_up_color_path(@color)
    post vote_up_color_path(@color)
    follow_redirect!
    assert_match 'class="advice"', response.body
    assert_match '<p class="alert">', response.body
    assert_match "You already voted!", response.body
  end

  test "bug 3: validation errors render as a list, not a raw array" do
    u = User.find_by(email: ENV["ADMIN_EMAIL"])
    post user_session_path, params: { user: { email: u.email, password: ENV["ADMIN_PASSWORD"] } }
    post colors_path, params: { color: { color1: "", color2: "#fff" } }

    assert_response :unprocessable_entity
    assert_match "prevented this post from saving", response.body
    assert_match "can&#39;t be blank", response.body
    refute_match(/\["Color1/, response.body)
    refute_match(/#&lt;ActiveModel/, response.body)
  end

  test "admin sees Edit and Delete, anonymous does not" do
    get color_path(@color)
    refute_match(/>Edit<|>Delete</, response.body)

    u = User.find_by(email: ENV["ADMIN_EMAIL"])
    post user_session_path, params: { user: { email: u.email, password: ENV["ADMIN_PASSWORD"] } }
    get color_path(@color)
    assert_match(/>Edit<|>Delete</, response.body)
  end

  test "trend orders by votes_count" do
    post vote_up_color_path(@color)
    get trend_colors_path
    assert_response :success
    top = Color.order(votes_count: :desc, created_at: :desc).first
    assert_equal Color.maximum(:votes_count), top.votes_count
  end
end
