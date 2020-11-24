require 'rails_helper'

shared_examples_for "user_stamps" do
  let (:user) { create(:user, first_name: "Joe", last_name: "Stevenson") }
  let (:other_user) { create(:user, first_name: "Amanda", last_name: "Bynes")  }

  before(:each) do
    User.current_user = user
  end

    describe "methods" do
      describe "created_by" do
        it "should return the creator" do
          expect(item.created_by).to eq user.full_name
        end
      end

      describe "updated_by" do 
        it "should return the updator" do
          User.current_user = other_user
          item.save
          expect(item.updated_by).to eq other_user.full_name
        end
      end

      describe "is_creator" do
        it "should return true if the current user is the creator" do
          expect(item.is_creator).to be true
        end

        it "should return false if the current user is not the creator" do
          item.save # load the item and save it before switching the current user
          User.current_user = other_user
          expect(item.is_creator).to be false
        end
      end

      describe "is_updater" do
        it "should return true if the current user is the updater" do
          item.save
          expect(item.is_updater).to be true
        end

        it "should return false if the current user is not the updater" do
          User.current_user = other_user
          item.save
          User.current_user = user
          expect(item.is_updater).to be false
        end
      end
    end
end