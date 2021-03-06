# 💀 DEPRECATED 💀
## 🌟 New awesome Gem with more Features: [Active Entry](https://github.com/TFM-Agency/active_entry)

ActionControl
=============

[![Build Status](https://travis-ci.org/tobiasfeistmantl/action_control.svg?branch=master)](https://travis-ci.org/tobiasfeistmantl/action_control)
[![Gem Version](https://badge.fury.io/rb/action_control.svg)](https://badge.fury.io/rb/action_control)

ActionControl is a simple and secure authentication and authorization system which let you to authenticate and authorize directly in your controllers.

Compatibility
-------------

I've tested it with a Rails 4.2.5 App but I think it should work with a lot versions of Rails since the gem uses just basic stuff of Rails.

Installation
------------

Just add the following line to the Gemfile of Rails:

```ruby
gem 'action_control'
```

And then `bundle install` and you are ready to go.

Short tutorial
--------------

With ActionControl authentication and authorization is done in you controllers. To enable authentication and authorization in one of your controllers, just add a before action for `authenticate!` and `authorize!` and the user has to authenticate and authorize on every call.
You probably want to control authentication and authorization for every controller action you have in your app. To enable this just add the before action to the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate!, :authorize!
end
```

If you try to open a page you will get an `ActionControl::AuthenticationNotPerformedError` or `ActionControl::AuthorizationNotPerformedError`. This means that you have to instruct ActionControl when a user is authorized and when not. You can do this by creating a method called `authenticated?` and `authorized?` in your controller.

```ruby
class DashboardController < ApplicationController
  def index
  end

  private

  def authenticated?
    return true if user_signed_in?
  end

  def authorized?
    return true if current_user.admin?
  end 
end
```

If the user is now signed in, he is authenticated and authorized if he is an admin, otherwise an `ActionControl::NotAuthenticatedError` or `ActionControl::NotAuthorizedError` will be raised. Now you just have to catch this error and react accordingly. Rails has the convinient `rescue_from` for this case.

```ruby
class ApplicationController < ActionController::Base
  # ...

  rescue_from ActionControl::NotAuthenticatedError, with: :user_not_authenticated
  rescue_from ActionControl::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authenticated
    flash[:danger] = "You are not authenticated!"
    redirect_to root_path
  end

  def user_not_authorized
    flash[:danger] = "You are not authorized to call this action!"
    redirect_to root_path
  end
end
```

In this example above, the user will be redirected to the root with a flash message. But you can do whatever you want. For example redirect to the sign in page.

ActionControl also has a view helper methods implemented which help you to distinguish between RESTful controller actions.

The following methods are available:

 * `read_action?` - If the called action just read. Actions: `index`, `show`
 * `write_action?` - If the called action writes something. Actions: `new`, `create`, `edit`, `update`, `destroy`
 * `change_action?` - If something will be updated or destroyed. Actions: `edit`, `update`, `destroy`
 * `create_action?` - If something will be created. Actions: `new`, `create`
 * `update_action?` - If something will be updated. Actions: `edit`, `update`
 * `destroy_action?` - If something will be destroyed. Action: `destroy`

So you can for example do:

```ruby
def authorized?
  return true if read_action?    # Everybody is authorized to call read actions

  if write_action?
    return true if admin_signed_in?		# Just admins are allowed to write something
  end
end
```

This is pretty much everything you have to do for basic authentication or authorization! As you can see it's quite flexible and straightforward to use.

Pass a custom error hash
------------------------

You can pass an error hash to the exception and use this in your rescue method:

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate!, :authorize!
	
  # ...

  rescue_from ActionControl::NotAuthenticatedError, with: :user_not_authenticated
  rescue_from ActionControl::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authenticated(exception)
    flash[:danger] = "You are not authenticated! Code: #{exception.error[:code]}"
    redirect_to root_path
  end

  def user_not_authorized(exception)
    flash[:danger] = "You are not authorized to call this action! Code: #{exception.error[:code]}"
    redirect_to root_path
  end

  def authenticated?(error)
    error[:code] = "ERROR"

    return true if user_signed_in?
  end
	
  def authorized?(error)
    error[:code] = "ERROR"

    return true if read_action?    # Everybody is authorized to call read actions

    if write_action?
      return true if admin_signed_in?		# Just admins are allowed to write something
    end
  end
end
```

Known Issues
------------

The authorization is done in a simple before action. Before callbacks are done in a specific order. If you set something which is needed in the `authenticate!` or `authorized?` method you have to call the before action after the other method again.

For example if you set `@user` in your controller in the `set_user` before action and you want to use this in `authorized?` action you have to add the `authenticate!` or `authorize!` method after the `set_user` again, otherwise `@user` won't be available in `authenticate!` or `authorized?`.

```ruby
class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate!, :authorize!

  def show
  end

  private

  def authenticated?
    return true if user_signed_in?
  end

  def authorized?
    return true if current_user == @user
  end
end
```

Contribution
------------

Create pull requests on Github and help us to improve this Gem. There are some guidelines to follow:

 * Follow the conventions
 * Test all your implementations
 * Document methods aren't self-explaining (we are using [YARD](http://yardoc.org/))

Copyright (c) 2016 Tobias Feistmantl, MIT license
