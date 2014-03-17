TJLMemoization
===========
Simple memoization (which is just a fancy term for "calculate this value once, cache it and return the cached value on subsequent calls") for Objective-C methods. Adds a category to NSObject that lets you memoize any selector on any instance of an object.

Usage
===========
Memoization is useful when you need to perform the same computationally intense calculation many times over, but don't want to compute the results over and over again. A good example is tableView row heights. Calculating the height in `tableView:heightForRowAtIndexPath:` can be expensive, so you only want to do it once. Memoizing the method that computes the height means that the height will only be calculated once, and a cached result will be returned on all subsequent calls.

```
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self memoizeAndInvokeSelector:@selector(paragraphsFromString:) withArguments:self.paragraphs, nil] objectAtIndex:(NSUInteger)indexPath.row];
    return [[self memoizeAndInvokeSelector:@selector(calculateHeightForText:atIndexPath:) withArguments:text, indexPath, nil] floatValue];
}
```
Note in this example we also memoized the calulation of the datasource array for the tableView, just for fun.

Installation
===========
TJLMemoization uses [cocoapods](http://cocoapods.org), so just put `pod 'TJLMemoization' 'version'` into your podfile and install like normal. then just `#import <TJLMemoization/TJLMemoization.h>` wherever you want to use it.

<h1>License</h1>
If you use TJLMemoization and you like it, feel free to let me know, <terry@ploverproductions.com>. If you have any issue or want to make improvements, submit a pull request.<br><br>

The MIT License (MIT)
Copyright (c) 2014 Terry Lewis II

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
<br><br>
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
<br><br>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
