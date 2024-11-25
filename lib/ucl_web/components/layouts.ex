defmodule UclWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use UclWeb, :controller` and
  `use UclWeb, :live_view`.
  """
  use UclWeb, :html

  embed_templates "layouts/*"
end
