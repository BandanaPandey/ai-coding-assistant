class AddUserToCodeEmbeddings < ActiveRecord::Migration[8.1]
  def change
    add_reference :code_embeddings, :user, foreign_key: true
    add_reference :code_embeddings, :repository, foreign_key: true

    remove_index :code_embeddings, column: :repo_path if index_exists?(:code_embeddings, :repo_path)
    remove_column :code_embeddings, :repo_path, :string
  end
end
