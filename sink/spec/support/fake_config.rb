# frozen_string_literal: true

FakeConfig = Struct.new(:port, :bind, :state_dir, :sync_dirs, keyword_init: true)
