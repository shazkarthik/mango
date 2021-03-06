defmodule Mango.Web.Router do
  use Mango.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :frontend  do
    plug Mango.Web.Plugs.LoadCustomer
    plug Mango.Web.Plugs.FetchCart
    plug Mango.Web.Plugs.Locale
  end

  pipeline :admin do
    plug Mango.Web.Plugs.AdminLayout
    plug Mango.Web.Plugs.LoadAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Mango.Web do
    pipe_through [:browser, :frontend]

    # Add all routes that don't require authentication
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    get "/", PageController, :index
    get "/categories/:name", CategoryController, :show

    get "/cart", CartController, :show
    post "/cart", CartController, :add
    put "/cart", CartController, :update
  end

  scope "/", Mango.Web do
    pipe_through [:browser, :frontend, Mango.Web.Plugs.AuthenticateCustomer]

    # Add all routes that require authentication
    get "/logout", SessionController, :delete
    get "/checkout", CheckoutController, :edit
    put "/checkout/confirm", CheckoutController, :update
    resources "/tickets", TicketController, except: [:edit, :update, :delete]
  end

  scope "/admin", Mango.Web.Admin, as: :admin do
    pipe_through [:browser, :admin]

    # Add all routes that don't require admin authentication
    get "/login", SessionController, :new
    post "/sendlink", SessionController, :send_link
    get "/magiclink", SessionController, :create
  end

  scope "/admin", Mango.Web.Admin, as: :admin do
    pipe_through [:browser, :admin, Mango.Web.Plugs.AuthenticateAdmin]

    # Add all routes that require admin authentication
    get "/", DashboardController, :show
    resources "/users", UserController
    resources "/orders", OrderController, only: [:index, :show]
    resources "/customers", CustomerController, only: [:index, :show]
    resources "/warehouse_items", WarehouseItemController
    resources "/suppliers", SupplierController
    get "/logout", SessionController, :delete
  end

end
