Dir.glob(File.join(LIB_ROOT, "zen_wallet", "persistence", "repositories", "*.rb")).each do |file|
  require "zen_wallet/persistence/repositories/#{File.basename(file, ".rb")}"
end
module StubRepoMixin
  private

  def stub_repo(*args)
    args.each do |repo|
      name = "#{repo}_repo"
      cls_name = Inflecto.camelize(name)
      repo_mock = mock
      repo_mock.responds_like_instance_of(ZenWallet::Persistence.const_get(cls_name))
      @container.register(name, repo_mock)
      instance_variable_set("@#{name}", repo_mock)
    end
  end
end
