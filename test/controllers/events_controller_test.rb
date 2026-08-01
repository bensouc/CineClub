require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:movie_night)
    @empty_event = events(:empty_night)
  end

  test "index requires authentication" do
    get events_path
    assert_redirected_to new_user_session_path
  end

  test "index renders for a signed-in user" do
    sign_in users(:alice)
    get events_path
    assert_response :success
  end

  test "show renders for a signed-in user" do
    sign_in users(:alice)
    get event_path(@event)
    assert_response :success
  end

  test "a non-admin cannot reach the event forms" do
    sign_in users(:alice)

    get new_event_path
    assert_redirected_to events_path
    assert_equal "Réservé aux administrateurs.", flash[:alert]

    get edit_event_path(@event)
    assert_redirected_to events_path
  end

  test "a non-admin cannot create, update or destroy an event" do
    sign_in users(:alice)

    assert_no_difference("Event.count") do
      post events_path, params: { event: { name: "Pirate", date: "2026-09-01" } }
    end
    assert_redirected_to events_path

    patch event_path(@event), params: { event: { name: "Détourné" } }
    assert_not_equal "Détourné", @event.reload.name

    assert_no_difference("Event.count") { delete event_path(@event) }
  end

  test "an admin creates an event" do
    sign_in users(:admin)

    assert_difference("Event.count", 1) do
      post events_path, params: { event: { name: "Soirée polar", date: "2026-09-01", venue: "outdoor" } }
    end

    event = Event.order(:created_at).last
    assert_redirected_to event_path(event)
    assert_equal "Soirée polar", event.name
    assert_equal Date.new(2026, 9, 1), event.date
    assert event.outdoor?
  end

  test "creating an invalid event re-renders the form" do
    sign_in users(:admin)

    assert_no_difference("Event.count") do
      post events_path, params: { event: { name: "", date: "" } }
    end

    assert_response :unprocessable_content
  end

  test "an admin updates an event" do
    sign_in users(:admin)

    patch event_path(@event), params: { event: { name: "Soirée renommée" } }

    assert_redirected_to event_path(@event)
    assert_equal "Soirée renommée", @event.reload.name
  end

  test "an admin destroys an event along with its choices" do
    sign_in users(:admin)

    assert_difference("Event.count", -1) do
      assert_difference("Choice.count", -@event.choices.count) do
        delete event_path(@event)
      end
    end

    assert_redirected_to events_path
  end

  test "the new event form renders for an admin" do
    sign_in users(:admin)

    get new_event_path
    assert_response :success

    get edit_event_path(@event)
    assert_response :success
  end
end
