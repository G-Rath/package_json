class PackageJson
  module Managers
    class NpmLike < Base
      def initialize(package_json, manager_cmd: "npm")
        super(package_json, manager_cmd: manager_cmd)
      end

      # Installs the dependencies specified in the `package.json` file
      def install(
        frozen: false,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        cmd = "install"
        cmd = "ci" if frozen

        args = with_native_args(
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )

        raw(cmd, args)
      end

      # Adds the given packages
      def add(
        packages,
        type: :production,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        args = with_native_args(
          package_type_install_flag(type),
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )

        raw("install", args + packages)
      end

      # Removes the given packages
      def remove(
        packages,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        args = with_native_args(
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )

        raw("remove", args + packages)
      end

      # Runs the script assuming it is defined in the `package.json` file
      def run(
        script_name,
        args = [],
        silent: false
      )
        raw("run", build_run_args(script_name, args, silent: silent))
      end

      # Provides the "native" command for running the script with args for embedding into shell scripts
      def native_run_command(
        script_name,
        args = [],
        silent: false
      )
        build_full_cmd("run", build_run_args(script_name, args, silent: silent))
      end

      private

      def build_run_args(script_name, args, silent:)
        # npm assumes flags prefixed with - are for it, unless they come after a "--"
        args = [script_name, "--", *args]

        args.unshift("--silent") if silent
        args
      end

      def with_native_args(
        *extra_args,
        ignore_scripts: nil,
        legacy_peer_deps: nil,
        omit_optional_deps: nil,
        _unsupported: []
      )
        args = [*extra_args]

        args << "--ignore-scripts" if ignore_scripts
        args << "--legacy-peer-deps" if legacy_peer_deps
        args << "--omit=optional" if omit_optional_deps

        args.compact
      end

      def package_type_install_flag(type)
        case type
        when :production
          "--save-prod"
        when :dev
          "--save-dev"
        when :optional
          "--save-optional"
        else
          raise Error, "unsupported package install type \"#{type}\""
        end
      end
    end
  end
end
