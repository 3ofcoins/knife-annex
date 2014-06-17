require 'chef/knife'

class Chef
  class Knife
    class Annex < Knife
      DATA_BAG = 'annex'
      IGNORE_USERS = ['admin']

      deps do
        require 'chef/user'
        require 'chef-vault'
      end

      banner "knife annex (options)"

      option :rotate_keys,
             :long => '--rotate-keys',
             :description => 'Update admin keys on items'

      def admins
        @admins ||= Chef::User.list.
          keys.
          select { |u| !IGNORE_USERS.include?(u) && Chef::User.load(u).admin }.
          join(',')
      end

      def annex_key
        ENV['ANNEX_KEY']
      end

      def annex_file
        ENV['ANNEX_FILE']
      end

      def item_id
        # We substitute characters invalid for data bag item id with
        # underscore, and add "__i" to allow any file extension
        # including ".keys" without confusing list for rekey.
        @item_id ||= annex_key.gsub(/[^[:alnum:]_\-]+/, '_') << "__i"
      end

      def run
        case ENV['ANNEX_ACTION']
        when 'store'
          begin
            item = ChefVault::Item.load(DATA_BAG, item_id)
          rescue ChefVault::Exceptions::KeysNotFound,
                 ChefVault::Exceptions::ItemNotFound
            item = ChefVault::Item.new(DATA_BAG, item_id)
          end
          item['data'] = File.read(annex_file)
          item.admins(admins)
          item.save
        when 'retrieve'
          item = ChefVault::Item.load(DATA_BAG, item_id)
          if annex_file
            File.write(annex_file, item['data'])
          else
            puts item['data']
          end
        when 'remove'
          delete_object(ChefVault::Item, "#{DATA_BAG}/#{item_id}", "chef_vault_item") do
            ChefVault::Item.load(DATA_BAG, item_id).destroy
          end
        when 'checkpresent'
          begin
            ChefVault::Item.load(DATA_BAG, item_id)
          rescue ChefVault::Exceptions::KeysNotFound,
                 ChefVault::Exceptions::ItemNotFound
            # not found, we do nothing
          else
            # found, print original key
            puts annex_key
          end
        else
          item_ids = ( @name_args.empty? ?
            Chef::DataBag.load(DATA_BAG).keys.grep(/__i$/) :
            @name_args )
          if config[:rotate_keys]
            item_ids.each do |item_id|
              item = ChefVault::Item.load(DATA_BAG, item_id)
              item.admins(item.admins.join(','), :delete)
              item.admins(admins)
              item.rotate_keys!
            end
          else
            puts "Use this command as git-annex hook"
          end
        end
      end
    end
  end
end
