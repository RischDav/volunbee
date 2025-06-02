namespace :images do
  desc "Reprocess all image variants"
  task reprocess: :environment do
    Position.where(online: true, released: true).find_each do |position|
      puts "Processing images for position: #{position.title}"
      
      [:main_picture, :picture1, :picture2, :picture3].each do |pic_attr|
        if position.send(pic_attr).attached?
          begin
            puts "  Processing #{pic_attr}..."
            # Force reprocessing of variants
            position.send(pic_attr).variant(resize_to_fill: [600, 250]).processed
            position.send(pic_attr).variant(resize_to_fill: [112, 112]).processed
            puts "  ✓ #{pic_attr} processed successfully"
          rescue => e
            puts "  ✗ Error processing #{pic_attr}: #{e.message}"
          end
        end
      end
    end
  end
end 