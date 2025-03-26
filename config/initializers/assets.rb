Rails.application.config.assets.precompile += %w[ application.tailwind.css tailwind.css ]
Rails.application.config.assets.precompile += %w( application.js )
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "builds")