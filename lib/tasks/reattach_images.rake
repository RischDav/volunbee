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
      begin
        # Temporarily redefine validation methods to bypass checks during reattachment
        position.instance_eval do
          def pictures_size
            true
          end

          def organization_position_limit
            nil
          end
        end

        # Find the organization name from the position title
        org_name = org_images.keys.find { |name| position.title.include?(name) }

        if org_name
          image_dir = org_images[org_name]
          # Find all suitable images in the directory
          image_paths = Dir.glob("public/images/#{image_dir}/*.{jpg,png}").sort

          # Attach up to 4 images
          [:main_picture, :picture1, :picture2, :picture3].each_with_index do |pic_attr, index|
            if image_paths[index]
              image_path = image_paths[index]
              puts "Attaching #{image_path} to position: #{position.title} as #{pic_attr}"
              
              # Add retry logic for database locks
              retries = 0
              begin
                position.send(pic_attr).attach(io: File.open(image_path), filename: File.basename(image_path))
              rescue SQLite3::BusyException => e
                retries += 1
                if retries <= 5
                  puts "Database locked, retrying in 1 second... (attempt #{retries}/5)"
                  sleep(1)
                  retry
                else
                  puts "Failed to attach image after 5 retries: #{e.message}"
                end
              end
            else
              puts "No image found for #{pic_attr} for position: #{position.title}"
            end
          end
        else
          puts "No matching organization found for position: #{position.title}"
        end

        # Add a longer delay between positions to help with SQLite concurrency
        sleep(1.0) # Sleep for 1 second
      rescue => e
        puts "Error processing position #{position.title}: #{e.message}"
        next
      end
    end
  end
end
