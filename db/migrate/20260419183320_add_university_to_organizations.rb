class AddUniversityToOrganizations < ActiveRecord::Migration[8.0]
  def change
    # null: true sorgt dafür, dass das Feld optional bleibt
    add_reference :organizations, :university, null: true, foreign_key: true
  end
end