module Bandiera
  class FeatureService
    class GroupNotFound < StandardError
      def message
        'This group does not exist in the Bandiera database.'
      end
    end

    class FeatureNotFound < StandardError
      def message
        'This feature does not exist in the Bandiera database.'
      end
    end

    def initialize(db = Db.connect)
      @db = db
    end

    # Groups

    def find_group(name)
      group = Group.find(name: name)
      raise GroupNotFound, "Cannot find group '#{name}'" unless group
      group
    end

    def add_group(group)
      Group.find_or_create(name: group)
    end

    def fetch_groups
      Group.order(Sequel.asc(:name))
    end

    def fetch_group_features(group_name)
      find_group(group_name).features
    end

    # Features

    def fetch_feature(group, name)
      group_id = find_group_id(group)
      feature = Feature.first(group_id: group_id, name: name)
      raise FeatureNotFound, "Cannot find feature '#{name}'" unless feature
      feature
    end

    def add_feature(data)
      data[:group] = Group.find_or_create(name: data[:group])
      lookup       = { name: data[:name], group: data[:group] }
      Feature.update_or_create(lookup, data)
    end

    def add_features(features)
      features.map { |feature| add_feature(feature) }
    end

    def remove_feature(group, name)
      group_id      = find_group_id(group)
      affected_rows = Feature.where(group_id: group_id, name: name).delete
      raise FeatureNotFound, "Cannot find feature '#{name}'" unless affected_rows > 0
    end

    def update_feature(group, name, params)
      group_id  = find_group_id(group)
      feature   = Feature.first(group_id: group_id, name: name)
      raise FeatureNotFound, "Cannot find feature '#{name}'" unless feature

      fields = {
        description:    params[:description],
        active:         params[:active],
        user_groups:    params[:user_groups],
        percentage:     params[:percentage],
        start_timeslot: params[:start_timeslot],
        end_timeslot:   params[:end_timeslot]
      }.delete_if { |_k, v| v.nil? }
      feature.update(fields)
    end

    private

    def find_group_id(name)
      group_id = Group.where(name: name).get(:id)
      raise GroupNotFound, "Cannot find group '#{name}'" unless group_id
      group_id
    end

    attr_reader :db
  end
end
