RegexGolf::Application.routes.draw do
	root :to => 'golf#index'
	get 'lists' => 'golf#lists'
	get 'matches' => 'golf#matches'
end
