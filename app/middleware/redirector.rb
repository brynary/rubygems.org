class Redirector
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host != expected_host_without_port && request.path !~ %r{^/api}
      fake_request = Rack::Request.new(env.merge("HTTP_HOST" => HOST))
      [301, {"Location" => fake_request.url}, []]
    elsif request.path =~ %r{^/(book|chapter|export|read|shelf|syndicate)}
      [301, {"Location" => "http://docs.rubygems.org#{request.path}"}, []]
    else
      @app.call(env)
    end
  end

private

  def expected_host_without_port
    HOST.to_s.gsub(/:\d+\z/, '')
  end

end
