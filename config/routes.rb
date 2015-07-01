Rails.application.routes.draw do
	get "/:test_type" => "testing#show", test_type: /[a-z-]+/
	root to: "home#index"
end
