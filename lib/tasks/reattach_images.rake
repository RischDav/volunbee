namespace :images do
  desc "Reattach images to positions"
  task reattach: :environment do
    # Map of organization names to their image directories
    org_images = {
      'Landesspiele' => 'specialOlympics',
      'UNICEF' => 'unicef',
      'Firefighter' => 'fireDepartment',
      'TED' => 'tedx',
      'Developer' => 'stock',
      'Support IT' => 'stock',
      'web design' => 'stock'
    }

    Position.where(online: true, released: true).each do |position|
      # Find the organization name from the position title
      org_name = org_images.keys.find { |name| position.title.include?(name) }
      
      if org_name
        image_dir = org_images[org_name]
        # Try to find a suitable image
        image_path = Dir.glob("public/images/#{image_dir}/*.{jpg,png}").first
        
        if image_path
          puts "Attaching #{image_path} to position: #{position.title}"
          position.main_picture.attach(io: File.open(image_path), filename: File.basename(image_path))
        else
          puts "No image found for position: #{position.title}"
        end
      else
        puts "No matching organization found for position: #{position.title}"
      end
    end
  end
end 