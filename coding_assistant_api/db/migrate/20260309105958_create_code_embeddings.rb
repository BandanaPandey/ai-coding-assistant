class CreateCodeEmbeddings < ActiveRecord::Migration[8.1]
  def change
    #enable_extension "vector"

    create_table :code_embeddings do |t|
      t.string :file_path
      t.text :content
      t.vector :embedding, limit: 768
      t.timestamps
    end
  end
end