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
          select { |u| !IGNORE_USERS.include?(u) && Chef::User.load(u).admin }
      end

      def annex_key
        ENV['ANNEX_KEY'].gsub(/[^[:alnum:]_\-]+/, '_')
      end

      def annex_file
        ENV['ANNEX_FILE']
      end

      def run
        case ENV['ANNEX_ACTION']
        when 'store'
          begin
            item = ChefVault::Item.load(DATA_BAG, annex_key)
          rescue ChefVault::Exceptions::KeysNotFound,
                 ChefVault::Exceptions::ItemNotFound
            item = ChefVault::Item.new(DATA_BAG, annex_key)
          end
          item['data'] = File.read(annex_file)
          item.admins(admins.join(','))
          item.save
        when 'retrieve'
          item = ChefVault::Item.load(DATA_BAG, annex_key)
          if annex_file
            File.write(annex_file, item['data'])
          else
            puts item['data']
          end
        when 'remove'
          delete_object(ChefVault::Item, "#{vault}/#{item}", "chef_vault_item") do
            ChefVault::Item.load(DATA_BAG, annex_key).destroy
          end
        when 'checkpresent'
          begin
            ChefVault::Item.load(DATA_BAG, annex_key)
          rescue ChefVault::Exceptions::KeysNotFound,
                 ChefVault::Exceptions::ItemNotFound
            # not found, we do nothing
          else
            # found
            puts annex_key
          end
        else
          items = ( @name_args.empty? ?
            Chef::DataBag.load(DATA_BAG).keys.reject { |k| k =~ /_keys$/ } :
            @name_args )
          if config[:rotate_keys]
            p rotate: items
          else
            puts "Use this command as git-annex hook"
          end
        end
      end
    end
  end
end
