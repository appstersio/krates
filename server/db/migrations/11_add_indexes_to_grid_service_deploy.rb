class AddIndexesToGridServiceDeploy < Mongodb::Migration
  def self.up
    GridServiceDeploy.create_indexes
  end
end
