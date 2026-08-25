Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      foreign_key :post_id, :posts, null: false
      String :path, null: false
      String :caption, null: false, default: ''
      Integer :position, null: false
    end
  end
end
