Sequel.migration do
  change do
    alter_table(:posts) do
      add_column :link_url, String, null: false, default: ''
      add_column :link_name, String, null: false, default: ''
      add_column :link_source, String, null: false, default: ''
    end
  end
end
