class CreateFrequentlyAskedQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :frequently_asked_questions do |t|
      t.string :question
      t.text :answer
      t.references :position, null: false, foreign_key: true

      t.timestamps
    end
  end
end
