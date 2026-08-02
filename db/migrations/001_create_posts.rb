Sequel.migration do
  change do
    create_table(:posts) do
      primary_key :id
      String :text, null: false
      Time :posted_at, null: false
      DateTime :created_at, null: false
    end
  end
end
