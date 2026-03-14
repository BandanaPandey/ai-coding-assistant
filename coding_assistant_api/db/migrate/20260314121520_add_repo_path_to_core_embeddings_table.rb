class AddRepoPathToCoreEmbeddingsTable < ActiveRecord::Migration[8.1]
  def change
    add_column :code_embeddings, :repo_path, :string
    add_index :code_embeddings, :repo_path
  end
end
