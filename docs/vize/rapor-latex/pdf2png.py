import sys, os
import Quartz
from Quartz import CGPDFDocumentCreateWithURL, CGPDFDocumentGetNumberOfPages, CGPDFDocumentGetPage
from Quartz import CGPDFPageGetBoxRect, kCGPDFMediaBox
from Quartz import CGBitmapContextCreate, CGColorSpaceCreateDeviceRGB, CGContextDrawPDFPage
from Quartz import CGBitmapContextCreateImage, CGContextSetRGBFillColor, CGContextFillRect
from Quartz import CGContextScaleCTM, CGContextTranslateCTM
from CoreFoundation import CFURLCreateFromFileSystemRepresentation, kCFAllocatorDefault
from Quartz import CGImageDestinationCreateWithURL, CGImageDestinationAddImage, CGImageDestinationFinalize
from Foundation import NSURL

src = sys.argv[1]
outdir = sys.argv[2]
scale = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0

os.makedirs(outdir, exist_ok=True)
url = NSURL.fileURLWithPath_(src)
doc = CGPDFDocumentCreateWithURL(url)
n = CGPDFDocumentGetNumberOfPages(doc)
print("pages:", n)

for i in range(1, n + 1):
    page = CGPDFDocumentGetPage(doc, i)
    box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox)
    w = int(box.size.width * scale)
    h = int(box.size.height * scale)
    cs = CGColorSpaceCreateDeviceRGB()
    ctx = CGBitmapContextCreate(None, w, h, 8, 0, cs, 1)
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1)
    CGContextFillRect(ctx, Quartz.CGRectMake(0, 0, w, h))
    CGContextScaleCTM(ctx, scale, scale)
    CGContextDrawPDFPage(ctx, page)
    img = CGBitmapContextCreateImage(ctx)
    out = os.path.join(outdir, "page%02d.png" % i)
    ourl = NSURL.fileURLWithPath_(out)
    dest = CGImageDestinationCreateWithURL(ourl, "public.png", 1, None)
    CGImageDestinationAddImage(dest, img, None)
    CGImageDestinationFinalize(dest)
    print(out, w, h)
