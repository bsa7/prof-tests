Rails.application.routes.draw do
	get "/check_answer" => "testing#check"
	get "/:test_type" => "testing#show", test_type: /[a-z\-_]+/
	root to: "home#index"
end
