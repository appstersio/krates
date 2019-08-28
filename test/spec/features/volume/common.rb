module Common

  # Finds a containers "fully qualified" name for inspection etc. container commands
  #
  # @param [String] container to find
  # @return [String] fully qualified container path, i.e. node/stack.container
  def find_container(name)
    `krates container ls`.match(/^\w*\/#{name}/)
  end

  # Get container Mounts
  #
  # @param [String] container, full path
  # @return [Hash] containers mounts
  def container_mounts(container)
    k = run "krates container inspect #{container}"
    JSON.parse(k.out).dig('Mounts')
  end

end
