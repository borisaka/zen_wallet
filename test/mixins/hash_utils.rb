module StrUtils
  module_function

  def camelize(str)
    str.split(/-|_/).map(&:capitalize).join
  end

  def decamelize(str, rep)
    str.gsub(/\p{Lu}/, rep + '\0').gsub(/^#{rep}/, '').downcase
  end

  def dasherize(str)
    decamelize(str, '-').tr('_', '-')
  end

  def underscore(str)
    decamelize(str, '_').tr('-', '_')
  end
end

module HashUtils
  module_function

  def deep_transform(obj, &blk)
    case obj
    when Hash
      Hash[obj.map { |k, val| [yield(k), deep_transform(val, &blk)] }]
    when Array
      obj.map { |item| deep_transform(item, &blk) }
    else
      obj
    end
  end

  def symbolize_keys(hsh)
    deep_transform(hsh, &:to_sym)
  end

  def stringify_keys(hsh)
    deep_transform(hsh, &:to_s)
  end

  def camelize_keys(hsh)
    deep_transform(hsh) { |k| StrUtils.camelize(k.to_s) }
  end

  def underscore_keys(hsh)
    deep_transform(hsh) { |k| StrUtils.underscore(k.to_s) }
  end

  def dasherize_keys(hsh)
    deep_transform(hsh) { |k| StrUtils.dasherize(k.to_s) }
  end
end
