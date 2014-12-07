
[1mFrom:[0m /home/tony/workspace/shopify_product_uploader/application.rb @ line 27 self.POST /upload:

    [1;34m22[0m:   product = params[[31m[1;31m"[0m[31mproduct[1;31m"[0m[31m[0m]
    [1;34m23[0m:   images =[]
    [1;34m24[0m:   product[[31m[1;31m"[0m[31mimages[1;31m"[0m[31m[0m].each_with_index [32mdo[0m |image|
    [1;34m25[0m:     binding.pry
    [1;34m26[0m:     images.push({ [35mattachment[0m:  [1;34;4mBase64[0m.encode64(open(image[[33m:tempfile[0m]) { |io| io.read })})
 => [1;34m27[0m:     binding.pry
    [1;34m28[0m:   [32mend[0m
    [1;34m29[0m: 
    [1;34m30[0m:   [1;34m# Create a new product[0m
    [1;34m31[0m:   new_product = [1;34;4mShopifyAPI[0m::[1;34;4mProduct[0m.new
    [1;34m32[0m: 

