V1::ServicesApi.route('service_container_logs') do |r|

  # GET /v1/services/:grid_name/:service_name/container_logs
  r.get do
    r.is do
      scope = @grid_service.with(read: { mode: :secondary_preferred }) do |klass|
        klass.container_logs.includes(:host_node, :grid, :grid_service)
      end

      scope = scope.where(:name => r['container']) unless r['container'].nil?
      scope = scope.where(:instance_number => r['instance'].to_i) unless r['instance'].nil?
      scope = scope.where(:$text => {:$search => r['search']}) unless r['search'].nil?

      render_container_logs(r, scope)
    end
  end
end
