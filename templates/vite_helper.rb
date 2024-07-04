# app/helpers/vite_helper.rb
module ViteHelper
  MANIFEST_PATH = "#{Rails.root}/public/.vite/manifest.json".freeze
  VITE_SERVER = "http://localhost:5173".freeze
  PREFIX = "app/javascript".freeze

  def vite_entry_tag(entry)
    if use_vite_server?
      safe_join(
        [
          tag.script(type: "module", src: "#{VITE_SERVER}/@vite/client"),
          tag.script(type: "module", src: "#{VITE_SERVER}/#{PREFIX}/packs/#{entry}.js"),
        ],
        "\n",
      )
    else
      safe_join(
        [
          vite_javascript_tag(entry),
          vite_stylesheet_tag(entry),
        ],
        "\n",
      )
    end
  end

  def vite_image_path(entry)
    raise ArgumentError, "Extname is missing with #{entry}" unless File.extname(entry).present?

    if use_vite_server?
      "#{VITE_SERVER}/#{PREFIX}/images/#{entry}"
    else
      path = vite_manifest.fetch("#{PREFIX}/images/#{entry}").fetch("file")
      asset_path("/#{path}")
    end
  end

  # entry 拡張子付きで指定
  def vite_image_tag(entry, **)
    tag.img(src: vite_image_path(entry), **)
  end

  private
  def vite_javascript_tag(entry, **options)
    path = vite_manifest.fetch("app/javascript/packs/#{entry}.js").fetch("file")

    options = {
      src: asset_path("/#{path}"),
      defer: true,
    }.merge(options)

    # async と defer を両方指定した場合、ふつうは async が優先されるが、
    # defer しか対応してない古いブラウザの挙動を考えるのが面倒なので、両方指定は防いでおく
    if options[:async]
      options.delete(:defer)
    end

    javascript_include_tag "", **options
  end

  def vite_stylesheet_path(entry)
    path = vite_manifest.fetch("app/javascript/packs/#{entry}.js").fetch("css")[0]
    asset_path("/#{path}")
  end

  def vite_stylesheet_tag(entry, **options)
    options = {
      href: vite_stylesheet_path(entry),
    }.merge(options)

    stylesheet_link_tag "", **options
  end

  def vite_manifest
    @vite_manifest ||= JSON.parse(File.read(MANIFEST_PATH))
  end

  def use_vite_server?
    !!Rails.application.config.use_vite_server
  end
end
