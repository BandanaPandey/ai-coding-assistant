class AddFilePathNStartLineToCoreEmbeddings < ActiveRecord::Migration[8.1]
  def change
    add_column :code_embeddings, :file_hash, :string
    add_column :code_embeddings, :start_line, :integer
    add_index :code_embeddings, :file_path
  end
end
