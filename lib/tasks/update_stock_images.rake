namespace :images do
  desc "Update stock images in positions"
  task update_stock: :environment do
    # Find positions that should use stock images
    stock_positions = Position.where(online: true, released: true)
                            .where("title LIKE ? OR title LIKE ? OR title LIKE ?", 
                                  "%web design%", 
                                  "%Developer%", 
                                  "%Support IT%")

    stock_positions.each do |position|
      # Attach the volunteerheilbronn logo
      if position.main_picture.attached?
        position.main_picture.purge # Remove existing attachment
      end
      
      position.main_picture.attach(
        io: File.open(Rails.root.join('public/images/stock/volunteerheilbronn_logo.jpg')),
        filename: 'volunteerheilbronn_logo.jpg'
      )
      
      puts "Updated image for position: #{position.title}"
    end
  end
end 