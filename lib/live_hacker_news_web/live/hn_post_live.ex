defmodule LiveHackerNewsWeb.HnPostLive do
  @moduledoc """
  The LiveView Implementation for all the interactive realtime features
  """
  use Phoenix.LiveView
  alias LiveHackerNews.Post

  def mount(_session, socket) do
    # Create a topic for others to join
    Phoenix.PubSub.subscribe(LiveHackerNews.PubSub, "hacker_news")

    # Assign a random funny name
    usernames = [
      "Flowers_Hnads",
      "Websites_Ice_cream",
      "Breakfast_YouTube",
      "YouTube_Ice_cream_cone",
      "Ice_cream_cone_Fence",
      "Video_games_System",
      "Cone_Toolbox",
      "Video_games_Printer",
      "Ring_Drugs",
      "Ice_cream_Solar",
      "Dislike_Poop",
      "Light_saber_Clock",
      "Book_Shoe",
      "Towel_BBQ",
      "Ice_cream_cone_Prints",
      "Sink_Bird",
      "Plus_Laptop",
      "Breakfast_Video_games",
      "Comics_Trees",
      "Android_Breakfast",
      "Monster_Poop",
      "Websites_Water",
      "Allergies_Crab",
      "Fusion_Crab",
      "Toolbox_Trees",
      "Ice_cream_cone_Horse",
      "Nuclear_Laptop",
      "Fusion_Trees",
      "Fusion_Printer",
      "Water_Toilet",
      "Soda_Monster",
      "Settings_Breakfast",
      "Sink_Comics",
      "Monster_Trees",
      "Hnads_Whale",
      "Comics_Websites",
      "Prints_Fence",
      "Elevator_Clock",
      "Mail_Monster",
      "Ice_cream_cone_Fusion",
      "Ring_Robot",
      "Dog_Breakfast",
      "Male_Websites",
      "Dog_Shoe",
      "Ring_Male",
      "Websites_Printer",
      "Leash_Bird",
      "Light_saber_Cat",
      "Breakfast_Boat",
      "Clock_Printer"
    ]

    username = Enum.random(usernames)
    form_state = "none"
    posts = fetch_posts()

    {:ok, assign(socket, username: username, form_state: form_state, posts: posts)}
  end

  def render(assigns) do
    LiveHackerNewsWeb.PostView.render("post_index.html", assigns)
  end

  # Open form to submit a new Post
  def handle_event("submit", username, socket) do
    form_state = "block"

    {:noreply, assign(socket, username: username, form_state: form_state)}
  end

  # Hide form used to submit a new Post
  def handle_event("hide_form", _, socket) do
    form_state = "none"

    {:noreply, assign(socket, form_state: form_state)}
  end

  # Create a new Post
  def handle_event("add_post", %{"link" => link}, socket) do
    Post.create_link(link)
    posts = fetch_posts()

    Phoenix.PubSub.broadcast(
      LiveHackerNews.PubSub,
      "hacker_news",
      {__MODULE__, "add_post", %{posts: posts}}
    )

    {:noreply, assign(socket, form_state: "none", posts: posts)}
  end

  # Upvote Post
  def handle_event("upvote", id, socket) do
    post = Post.get_link!(id)
    Post.update_link(post, %{upvotes: post.upvotes + 1})
    posts = fetch_posts()

    Phoenix.PubSub.broadcast(
      LiveHackerNews.PubSub,
      "hacker_news",
      {__MODULE__, "upvote", %{posts: posts}}
    )

    {:noreply, assign(socket, form_state: "none", posts: posts)}
  end

  # Sort by newest posts
  def handle_event("new", _, socket) do
    posts = fetch_posts()

    {:noreply, assign(socket, form_state: "none", posts: posts)}
  end

  # Sort by earlier posts
  def handle_event("past", _, socket) do
    posts = Post.get_links_for_past()

    {:noreply, assign(socket, form_state: "none", posts: posts)}
  end

  # Handle Channel Sockets
  def handle_info({LiveHackerNewsWeb.HnPostLive, _action, payload}, socket) do
    {:noreply, assign(socket, payload)}
  end

  defp fetch_posts do
    Post.get_links_for_today()
  end
end
